shared_examples_for 'disables updating initramfs' do
  let(:disable_initramfs) { %(echo update_initramfs=no | sudo tee -a /etc/initramfs-tools/update-initramfs.conf > /dev/null) }

  it 'disables updating initramfs' do
    should include_sexp [:raw, disable_initramfs]
  end
end